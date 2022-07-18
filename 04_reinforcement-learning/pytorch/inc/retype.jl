"再定義可能な構造体を定義するマクロ"
macro restruct(exp)
    tmpname = "var\"$(gensym())\""
    mutable = exp.args[1] ? "mutable" : ""
    name, extend = if typeof(exp.args[2]) === Expr
        if exp.args[2].head === :curly
            (exp.args[2].args[1], "{$(exp.args[2].args[2])}")
        else
            (exp.args[2].args[1], "<: $(exp.args[2].args[2])")
        end
    else
        (exp.args[2], "")
    end
    structcode = join(exp.args[3].args, ";")

    Meta.parse(
        "Base.@kwdef $mutable struct $(tmpname)$(extend) $structcode end; $name = $tmpname"
    ) |> eval
end

"再定義可能な型定義を行うマクロ"
macro retype(exp)
    tmpname = "var\"$(gensym())\""
    name = exp.args[1]
    Meta.parse("$(exp.head) type $tmpname end; $name = $tmpname") |> eval
end
