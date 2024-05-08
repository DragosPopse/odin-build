package build
import "core:hash"
import "core:os"
import "core:fmt"
import "core:mem"
import "core:path/filepath"
import "core:strings"
import "core:strconv"
import "core:slice"

Build_Cache :: struct {
	// Target name -> hash
	checksums: map[string]u64,
}

// Maybe a dumb implementation? Who knows. It's fast enough.
hash_target :: proc(target: ^Target) -> u64 {
	hashes := make([dynamic]u64, 0, len(target.sources))
	for source in target.sources {
		if strings.contains_rune(source, '*') {
			source := tabspath(target, source)

			globbed_paths, err := filepath.glob(source)
			fmt.assertf(err == nil, "Match error for glob path: %v", err)
			for path in globbed_paths {
				data, ok := os.read_entire_file(path)
				fmt.assertf(ok, "Failed to read target source: %v", path)
				append(&hashes, hash.crc64_xz(data))
			}
		} else {
			data, ok := os.read_entire_file(tabspath(target, source))
			fmt.assertf(ok, "Failed to read target source: %v", source)
			append(&hashes, hash.crc64_xz(data))
		}
	}

	return hash.crc64_xz(mem.slice_to_bytes(hashes[:]))
}

read_build_cache :: proc() {
	cwd := os.get_current_directory()
	path := filepath.join({cwd, ".obuild"})

	file, ok := os.read_entire_file(path)
	if !ok do return

	line_iter := string(file)
	for line in strings.split_lines_iterator(&line_iter) {
		splits := strings.split(line, "=")
		// Invalid line, skip.
		if len(splits) != 2 do continue

		name := splits[0]
		parsed_length: int
		hash, parse_ok := strconv.parse_u64(splits[1], 10, &parsed_length)
		if !parse_ok do continue

		_build_cache.checksums[name] = hash
	}
}

write_build_cache :: proc() {
	cwd := os.get_current_directory()
	path := filepath.join({cwd, ".obuild"})

	file, ok := os.open(path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC)
	assert(ok == 0, "Failed to open cache file for reading")
	defer os.close(file)

	names, _ := slice.map_keys(_build_cache.checksums)
	slice.sort(names)

	for name in names {
		hash := _build_cache.checksums[name]
		if hash == 0 do continue
		os.write_string(file, fmt.tprintf("%v=%v\n", name, hash))
	}
}