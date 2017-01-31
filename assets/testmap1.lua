return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 200,
  height = 100,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {},
  layers = {
    {
      type = "objectgroup",
      name = "Solids",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "Ground",
          type = "ground",
          shape = "rectangle",
          x = 40,
          y = 5552,
          width = 12672,
          height = 784,
          visible = true,
          properties = {
            ["shader"] = "dirt"
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "Entities",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "Player1",
          type = "player",
          shape = "ellipse",
          x = 1578,
          y = 4269,
          width = 27,
          height = 27,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
