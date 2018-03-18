insulate("with love", function()
  _G.love = {}
  require("conf")

  describe("love.conf", function()
    local t

    before_each(function()
      t = {window={}}
      love.conf(t)
    end)

    it("sets the identity", function ()
      assert.truthy(t.identity)
    end)

    it("sets the version", function ()
      assert.truthy(t.version)
    end)

    it("sets the window title", function ()
      assert.truthy(t.window.title)
    end)
  end)
end)
