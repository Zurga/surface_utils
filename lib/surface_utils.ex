defmodule SurfaceUtils do
  @moduledoc """
  SurfaceUtils provides a include/2 macro which can import props from other components.

  Use the `included_props/2` function to pass included props to the component that is included. 


  For Example:
  ```
  defmodule ComponentToInclude do
    use Surface.Component

    @doc "a boolean"
    prop(boolean, :boolean)

    def render(assigns) do
      ~F\"\"\"
      ComponentToInclude
      {#for prop <- __MODULE__.__props__()}
        {assigns[prop.name]}
      {/for}
      \"\"\"
    end
  end

  defmodule TestComponent do
    use Surface.Component
    import SurfaceUtils

    include(ComponentToInclude)

    prop(own_prop, :any)

    def render(assigns) do
      ~F\"\"\"
      {"my_props: \#{@own_prop}"}
      <ComponentToInclude {...included_props(assigns, ComponentToInclude)} />
      \"\"\"
    end
  end
  ```
  """

  @doc """
  Allows a component to include props from another component.
  Props can be selectively included similarly to Elixir's `import` using `only: [list_of_names]` and `except: [list_of_names]`.
  """
  defmacro include(other_component, opts \\ []) do
    only = Keyword.get(opts, :only)
    except = Keyword.get(opts, :except)

    rename = Keyword.get(opts, :rename, [])

    if is_list(only) and is_list(except) do
      raise "Cannot use only and except together."
    end

    names =
      Enum.map(
        (is_list(only) && only) || except || [],
        fn
          {name, _} -> name
          name -> name
        end
      )

    filter =
      cond do
        is_list(only) ->
          quote do
            fn props -> Enum.filter(props, &(&1.name in unquote(names))) end
          end

        is_list(except) ->
          quote do
            fn props -> Enum.reject(props, &(&1.name in unquote(names))) end
          end

        true ->
          quote do
            fn props -> props end
          end
      end

    maybe_rename_props =
      quote do
        fn props, rename_mapping ->
          Enum.map(props, fn
            %{name: name} = prop ->
              %{prop | name: rename_mapping[name] || name}
          end)
        end
      end

    quote do
      import SurfaceUtils, only: [included_props: 2]

      for included_prop <-
            unquote(other_component).__props__()
            |> unquote(filter).()
            |> unquote(maybe_rename_props).(unquote(rename)) do
        Module.put_attribute(
          __MODULE__,
          :prop,
          included_prop
        )

        Module.put_attribute(
          __MODULE__,
          :assigns,
          included_prop
        )
      end
    end
  end

  @doc """
    Will extract the values for the props that are in the assigns for the specified component. Usefull when wrapping another component and the values for the props need to be passed on.
  """
  def included_props(assigns, other_component) do
    Enum.reduce(other_component.__props__(), %{}, fn %{name: name}, acc ->
      if Map.get(assigns, name) do
        Map.put(acc, name, assigns[name])
      else
        acc
      end
    end)
  end
end
