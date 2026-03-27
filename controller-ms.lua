local vector = require "vector"

MAX_VELOCITY = 15
L = 0

function init()
    robot.leds.set_all_colors("green")
    L = robot.wheels.axis_length
end
--vertore di crociera, che spinge il robot a muoversi in avanti
function cruise()
    local v = {length = 0.5, angle = 0.0}
    return v
end
-- vettore attrattivo verso la luce
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

-- vettore repulsivo dagli ostacoli
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

    -- Priorita' LED: rosso se ostacolo molto vicino, giallo se punta verso la luce.
    if max_prox > 0.95 then
        robot.leds.set_all_colors("red")
    elseif light_v.length > 0.1 and math.abs(light_v.angle) < 0.35 then
        robot.leds.set_all_colors("yellow")
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

    --trasformazione di v e omega da forza e direzione del vettore risultante
    local v = MAX_VELOCITY * strength * math.cos(angle)
    local omega = (2.0 * MAX_VELOCITY / L) * math.sin(angle)

    --trasformazione da velocità lineare e angolare a velocità delle ruote
    local vl = v - (L / 2) * omega
    local vr = v + (L / 2) * omega

    update_leds(light_v)

    robot.wheels.set_velocity(vl, vr)
end

function reset()
    robot.leds.set_all_colors("green")
end

function destroy()
end