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
    for {fn_list, {cb_mdl, cb_fn}} <- bangs do
      create_funcs(env.module, fn_list, cb_mdl, cb_fn)
    end
  end

  defp create_funcs(fn_mdl, fn_list, cb_mdl, cb_fn) do
    for {fn_name, arg_cnt} <- fn_list do
      create_func(fn_mdl, fn_name, arg_cnt, cb_mdl, cb_fn)
    end
  end

  defp create_func(fn_mdl, fn_name, arg_cnt, cb_mdl, cb_fn) do
    fn_args = create_args(fn_mdl, arg_cnt)
    create_ast(fn_mdl, fn_name, fn_args, :"#{fn_name}!", cb_mdl, cb_fn)
  end

  defp create_args(_, 0),
    do: []
  defp create_args(fn_mdl, arg_cnt),
    do: Enum.map(1..arg_cnt, &(Macro.var (:"arg#{&1}"), fn_mdl))

  defp create_ast(fn_mdl, fn_name, fn_args, bang_func, cb_mdl, cb_fn) do
    quote do
      @doc false
      def unquote(bang_func)(unquote_splicing(fn_args)) do
        value = apply(unquote(fn_mdl), unquote(fn_name), unquote(fn_args))
        apply(unquote(cb_mdl), unquote(cb_fn), [value])
      end
    end
  end
end
