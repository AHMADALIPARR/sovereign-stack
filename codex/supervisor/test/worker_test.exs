defmodule Codex.WorkerTest do
  use ExUnit.Case, async: false

  test "admission rejects over depth" do
    {:ok, _} = Codex.Supervisor.start_link()
    assert {:rejected, :max_depth_exceeded} =
             Codex.Admission.admit("t", depth: 5, max_depth: 4)
  end

  test "validator rejects bad command" do
    e = Codex.Grammar.Validator.validate_command("DROP table")
    refute e.valid
  end

  test "validator accepts good command" do
    e = Codex.Grammar.Validator.validate_command("READ /opt/sovereign/bin/tool")
    assert e.valid
  end
end
