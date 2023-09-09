func main() {
	int a = 5
	int b = 4
	int c = a + (a-b)
	print(c)
}
/*
// generated code
(module 
	(import "console" "log_number" (func $log_number (param i32)))
	(import "console" "log_bool" (func $log_bool (param i32)))
	(import "console" "log_string" (func $log_string (param i32)))
	(func (export "main")
	;; LOCAL VARIABLES: function_idx=0

	(local $c i32)
	(local $b i32)
	(local $a i32)
	i32.const 5
	(local.set $a)
	i32.const 4
	(local.set $b)
	local.get $a
	local.get $a
	local.get $b
	i32.sub
	i32.add
	(local.set $c)
	local.get $c
	call $log_number
	)
)
*/
