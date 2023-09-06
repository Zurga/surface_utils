defmodule SurfaceUtilsTest do
  use SurfaceUtils.ConnCase
  doctest SurfaceUtils

  defmodule ComponentToInclude do
    use Surface.Component

    @doc "a boolean"
    prop(boolean, :boolean)
    @doc "a string"
    prop(string, :string, default: "A string")
    @doc "a renamed"
    prop(to_rename, :any)
    prop(to_exclude, :any)

    def render(assigns) do
      ~F"""
      ComponentToInclude
      {#for prop <- __MODULE__.__props__()}
        {assigns[prop.name]}
      {/for}
      """
    end
  end

  defmodule TestComponent do
    use Surface.Component
    import SurfaceUtils
    alias SurfaceUtilsTest.ComponentToInclude

    include(ComponentToInclude)

    prop(own_prop, :any)

    def render(assigns) do
      ~F"""
      {"my_props: #{@own_prop}"}
      <ComponentToInclude {...included_props(assigns, ComponentToInclude)} />
      """
    end
  end

  defmodule TestComponentWithExclusion do
    use Surface.Component
    import SurfaceUtils
    alias SurfaceUtilsTest.ComponentToInclude

    include(ComponentToInclude, except: [:to_exclude])

    def render(assigns) do
      ~F[]
    end
  end

  defmodule TestComponentWithOnly do
    use Surface.Component
    import SurfaceUtils
    alias SurfaceUtilsTest.ComponentToInclude

    include(ComponentToInclude, only: [:boolean, :string])

    def render(assigns) do
      ~F[]
    end
  end

  defmodule TestComponentWithRename do
    use Surface.Component
    import SurfaceUtils
    alias SurfaceUtilsTest.ComponentToInclude

    include(ComponentToInclude, rename: [to_rename: :other_prop])

    def render(assigns) do
      ~F[]
    end
  end

  describe "includes/2" do
    test "can include props from other component" do
      assert Enum.reject(TestComponent.__props__(), &(&1.name == :own_prop)) ==
               ComponentToInclude.__props__()

      html =
        render_surface do
          ~F"""
                    <TestComponent boolean={true} own_prop={"Test"} />


          """
        end

      assert html =~ "my_props: Test"
      assert html =~ "ComponentToInclude\n  true\n  A string\n"
    end

    test "can exclude props from other component" do
      assert TestComponentWithExclusion.__props__() ==
               Enum.reject(ComponentToInclude.__props__(), &(&1.name == :to_exclude))
    end

    test "can include only certain props from other component" do
      assert TestComponentWithOnly.__props__() ==
               Enum.filter(ComponentToInclude.__props__(), &(&1.name in [:boolean, :string]))
    end

    test "can rename certain props from other component" do
      assert Enum.find(
               TestComponentWithRename.__props__(),
               &(&1.name == :other_prop)
             )
             |> Map.delete(:name) ==
               Enum.find(ComponentToInclude.__props__(), &(&1.name == :to_rename))
               |> Map.delete(:name)
    end
  end
end
