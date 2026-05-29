local vector = require "vector"

MAX_VELOCITY = 15
L = 0

function init()
    robot.leds.set_all_colors("green")
    L = robot.wheels.axis_length
end

-- Cruise schema: pushes the robot forward.
function cruise()
    local v = {length = 0.5, angle = 0.0}
    return v
end

-- Attraction schema: moves the robot towards the light.
function go_to_light()
    local v = {length = 0.0, angle = 0.0}

    for i = 1, #robot.light do
        local s = robot.light[i]
        if s.value > 0.0 then
            local c = {
                length = s.value,
                angle = s.angle
            }
            v = vector.vec2_polar_sum(v, c)
        end
    end
    return v
end

-- Repulsion schema: pushes the robot away from obstacles.
function avoid_obstacles()
    local v = {length = 0.0, angle = 0.0}

    for i = 1, #robot.proximity do
        local s = robot.proximity[i]
        if s.value > 0.0 then
            local c = {
                length = s.value * s.value * 2.0,
                angle = s.angle + math.pi
            }
            v = vector.vec2_polar_sum(v, c)
        end
    end
    return v
end

function update_leds(light_v)
    local max_prox = 0.0
    for i = 1, #robot.proximity do
        if robot.proximity[i].value > max_prox then
            max_prox = robot.proximity[i].value
        end
    end

    if max_prox > 0.95 then
        robot.leds.set_all_colors("red")
    else
        robot.leds.set_all_colors("green")
    end
end


function step()
    local cruise_vec = cruise()
    local light_v = go_to_light()
    local avoid_v = avoid_obstacles()

    local res = vector.vec2_polar_sum(light_v, avoid_v)
    res = vector.vec2_polar_sum(res, cruise_vec)

    local strength = res.length
    local angle = res.angle

    -- Convert the resulting force into linear and angular velocity.
    local v = MAX_VELOCITY * strength * math.cos(angle)
    local omega = (2.0 * MAX_VELOCITY / L) * math.sin(angle)

    -- Convert linear and angular velocity into wheel velocity.
    local vl = v - (L / 2) * omega
    local vr = v + (L / 2) * omega

    local max_abs = math.max(math.abs(vl), math.abs(vr))
    if max_abs > MAX_VELOCITY then
        local scale = MAX_VELOCITY / max_abs
        vl = vl * scale
        vr = vr * scale
    end

    update_leds(light_v)

    robot.wheels.set_velocity(vl, vr)
end

function reset()
    robot.leds.set_all_colors("green")
end

function destroy()
end
