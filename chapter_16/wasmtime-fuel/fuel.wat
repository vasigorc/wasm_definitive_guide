(module
  (func $fibonacci (param $n i32) (result i32)
    (if (result i32)
      (i32.lt_s (local.get $n) (i32.const 2))
      (then
        (local.get $n)
      )
      (else
        (i32.add
          (call $fibonacci (i32.sub (local.get $n) (i32.const 1)))
          (call $fibonacci (i32.sub (local.get $n) (i32.const 2)))
        )
      )
    )
  )
  (export "fibonacci" (func $fibonacci))
)
