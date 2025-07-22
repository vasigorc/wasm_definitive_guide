(module
  (table $table (export "table") 10 externref)

  (func (export "func") (param externref)(result externref)
        local.get 0
  )
)
