package build

import "core:unicode/utf8"
import "core:runtime"
import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:path/filepath"

import "core:c/libc"

// Creates a directory recursively or does nothing if it exists.
make_directory :: proc(name: string) {
	// Note(Dragos): I wrote this a while ago. Is there a better way?
	slash_dir, _ := filepath.to_slash(name, context.temp_allocator)
	dirs := strings.split_after(slash_dir, "/", context.temp_allocator)
	for _, i in dirs {
		new_dir := strings.concatenate(dirs[0 : i + 1], context.temp_allocator)
		os.make_directory(new_dir)
	}
}

exec :: proc(file: string, args: []string) -> int {
	//return _exec(file, args) // Note(Dragos): _exec is not properly implemented. Wait for os2
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	cmd := strings.join(args, " ", context.temp_allocator)
	cmd = strings.join({file, cmd}, " ", context.temp_allocator)
	cmd_c := strings.clone_to_cstring(cmd, context.temp_allocator)
	return cast(int)libc.system(cmd_c)
}

copy_file :: proc(src, dst: string) -> bool {
	data := os.read_entire_file(src) or_return
	os.write_entire_file(dst, data) or_return
	return true
}

copy_directory :: proc(src, dst: string) -> bool {
	if ODIN_OS != .Windows {
		panic("build.copy_directory is not supported on non-windows")
	}
	cmd := fmt.tprintf("robocopy \"%s\" \"%s\" /MIR /NFL /NDL /NJH /NJS /nc /ns /np", src, dst)
	result := exec(cmd, {})
	return result == 0
}