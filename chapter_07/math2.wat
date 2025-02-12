(module 
  (import "js" "table" (table 2 funcref))

  (func $add (param $a i32) (param $b i32) (result i32)
      local.get $a
      local.get $b
      i32.add)


  (func $sub (param $a i32) (param $b i32) (result i32)
      local.get $a
      local.get $b
      i32.sub)

  (; 0 and 1 here associate functions `add` and `sub` to their indices ;)
  (elem (i32.const 0) $add)
  (elem (i32.const 1) $sub)
  )
