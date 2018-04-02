local entityCount = 10000
local entities
local batch

local function createEntities()
  local windowWidth, windowHeight = love.graphics.getDimensions()

  local entityTable = {}

  for _ = 1, entityCount do
    local entity = {
      x = love.math.random() * windowWidth,
      y = love.math.random() * windowHeight,
      vx = (love.math.random() * 2 - 1) * 30,
      vy = (love.math.random() * 2 - 1) * 30,
      r = 0,
      vr = (love.math.random() * 2 - 1) * 2,
      color = {love.math.random(), love.math.random(), love.math.random()},
      scale = .1 + love.math.random() ^ 4 * .7
    }
    table.insert(entityTable, entity)
  end

  return entityTable
end

local function updateEntities(width, height, dt)
  for i = 1, #entities do
    local entity = entities[i]
    entity.x = (entity.x + entity.vx * dt) % width
    entity.y = (entity.y + entity.vy * dt) % height
    entity.r = entity.r + entity.vr * dt
  end
end

local function setupBatch()
  batch:clear()

  for i = 1, #entities do
    local entity = entities[i]
    batch:setColor(unpack(entity.color))
    batch:add(entity.x, entity.y, entity.r, entity.scale, entity.scale, 16, 16)
  end

  batch:flush()
end

local function drawBatch()
  love.graphics.draw(batch)
end

local function drawStats()
  local fps = love.timer.getFPS()
  local stats = love.graphics.getStats()

  love.graphics.setColor(0, 0, 0, .75)
  love.graphics.rectangle("fill", 5, 5, 110, 45, 2)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("FPS: " .. fps, 10, 10)
  love.graphics.print("Draw calls: " .. stats.drawcalls, 10, 30)
end

function love.load()
  local image = love.graphics.newImage("assets/star.png")

  entities = createEntities()
  batch = love.graphics.newSpriteBatch(image, entityCount)

  setupBatch()
end

function love.update(dt)
  local width, height = love.graphics.getDimensions()
  updateEntities(width, height, dt)
  setupBatch()
end

function love.draw()
  drawBatch()
  drawStats()
end
