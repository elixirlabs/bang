defmodule BangTest do
  use ExUnit.Case
  doctest Bang

  test "create bang functions for module" do
    expected_func_list = [good_bye: 1, good_bye: 2, good_bye!: 1, titleize: 1,
      welcome: 0, welcome: 1, welcome: 2, welcome!: 0, welcome!: 1, welcome!: 2]
    assert expected_func_list == SampleTestModule.__info__(:functions)
  end

  test "compare result of bang func with expected result" do
    result = SampleTestModule.welcome |> SampleTestModule.titleize
    assert SampleTestModule.welcome! == result
    result = SampleTestModule.welcome("turan") |> SampleTestModule.titleize
    assert SampleTestModule.welcome!("turan") == result
    result = SampleTestModule.welcome("mr", "turan") |> SampleTestModule.titleize
    assert SampleTestModule.welcome!("mr", "turan") == result
  end
end
