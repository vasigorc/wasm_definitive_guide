(module
  (func $add (param $a i32) (param $b i32) (result i32)
      local.get $a
      local.get $b
      i32.add)

  (func $sub (param $a i32) (param $b i32) (result i32)
      local.get $a
      local.get $b
      i32.sub)

  (; `table` defines a collection of function references;)
  (; the host can only invoke the behaviour;)
  (table (export "tbl") funcref (elem $add $sub))
)
