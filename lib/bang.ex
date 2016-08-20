defmodule Bang do
  @moduledoc """
  Creates an auto bang function with callback methods of result of non-bang
  function. Bang uses accumulated approach by definition. So, you can define
  several bangs inside your module and can use different callback for
  each `@bang` function.
  """

  @doc """
  Registers @bang attribute for the module

  ## Examples

      defmodule SomeModule do
        use Bang
        # now you can use @bang attribute to generate bang! functions
      end
  """
  defmacro __using__(_) do
    quote do
      Module.register_attribute __MODULE__, :bang, accumulate: true,
        persist: false
      @before_compile Bang
    end
  end

  @doc """
  Creates bang! functions using exisiting functions and callback function.
  You can use multiple `@bang` attributes to specify several callback functions.

  ## Examples

      # @bang {[list_of_func_name_arg_cnt_tuples], {CallbackModule, :callback_fn}}

      @bang {[welcome: 1, welcome: 2], {SampleTestModule, :titleize}}
      # or one by one
      @bang {[welcome: 1], {SampleTestModule, :titleize}}
      @bang {[welcome: 2], {SampleTestModule, :titleize}}

      # Both of two approaches create [welcome!: 1, welcome!: 2] functions using
      # existing [welcome: 1, welcome: 2] functions and after calls
      # SampleTestModule.titleize method using output of
      # [welcome: 1, welcome: 2]
  """
  defmacro __before_compile__(env) do
    bangs = Module.get_attribute(env.module, :bang)
    for {funcs, {callback_mdl, callback_fn}} <- bangs do
      create_funcs(env.module, funcs, callback_mdl, callback_fn)
    end
  end

  defp create_funcs(func_mdl, funcs, callback_mdl, callback_fn) do
    for {func, arg_cnt} <- funcs do
      create_func(func_mdl, func, arg_cnt, callback_mdl, callback_fn)
    end
  end

  defp create_func(func_mdl, func, arg_cnt, callback_mdl, callback_fn) do
    bang_func = String.to_atom "#{func}!"
    func_args = create_args(func_mdl, arg_cnt)

    ast = create_ast(func_mdl, func, func_args, bang_func,
      callback_mdl, callback_fn)

    Macro.postwalk(ast, fn
      ({func_name, context, []}) when func_name == bang_func ->
        {func_name, context, func_args}
      (other) -> other
    end)
  end

  defp create_args(func_mdl, 0),
    do: []
  defp create_args(func_mdl, arg_cnt),
    do: Enum.map(1..arg_cnt, &(Macro.var (String.to_atom "arg#{&1}"), func_mdl))

  defp create_ast(func_mdl, func, func_args, bang_func, callback_mdl, callback_fn) do
    quote do
      @doc false
      def unquote(bang_func)() do
        value = apply(unquote(func_mdl), unquote(func), unquote(func_args))
        apply(unquote(callback_mdl), unquote(callback_fn), [value])
      end
    end
  end
end
