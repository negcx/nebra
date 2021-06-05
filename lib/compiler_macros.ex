defmodule Compiler.Macros do
  defmacro binary_op(op) do
    quote do
      def compile({unquote(op), _, [left, right]}),
        do: "(" <> compile(left) <> " #{Atom.to_string(unquote(op))} " <> compile(right) <> ")"
    end
  end

  defmacro unary_op(op) do
    quote do
      def compile({unquote(op), _, [node]}),
        do: "#{Atom.to_string(unquote(op))} " <> compile(node)
    end
  end
end
