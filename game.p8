pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- player
fireball = {
  sprite = 3,
  drawing = false,
  position = { x = 0,  y = 0 },
  speed = 3
}

player = {}
player.x = 5
player.y = 10
player.sprite = 0
player.speed = 2
player.life = 5
player.max_life = 5
player.spells = {}
player.attacking = false
player.score = 0
player.spells = {}
player.spells["fireball"] = fireball

old_score = 0
gameover = false
last_time = time()
display_damage = false

function move()
  player.moving = true
  player.sprite += 1
  if player.sprite > 2 then
   player.sprite = 0
  end
end

function draw_player()
  if menu.display == false then
    spr(player.sprite, player.x, player.y)
    if player.attacking == true or player.spells.fireball.drawing == true then
      draw_fireball()
    end
  end
end

function draw_fireball()
  if menu.display == false then
    fireball_ = player.spells.fireball
    if fireball_.drawing == true then
      fireball_.position.x += fireball_.speed
      if fireball_.position.x > screen_size then
        fireball_.drawing = false
      end
    else
      sfx(0)
      fireball_.drawing = true
      fireball_.position.x = player.x + 4
      fireball_.position.y = player.y
    end
    spr(fireball_.sprite, fireball_.position.x, fireball_.position.y)
  end
end

function check_score()
  if player.score < 0 or player.life <= 0 then
    gameover = true
  end
  if player.score != 0 and old_score != player.score and player.score > old_score and player.score % 2 == 0 then
    foe.speed += 0.3
    old_score = player.score
  elseif player.score != 0 and old_score != player.screen_size and player.score > old_score and player.score % 5 == 0 then
    foe.max_life += 1
    old_score = player.score
  end
end

-- enemies
foe = {}
foe.sprite = 16
foe.sprite_death_start = 17
foe.sprite_death_stop = 28
foe.life = 1
foe.max_life = 1
foe.speed = 0.1
foe.drawing = false
foe.position = {x = 0, y = 0}

function draw_foes()
  if menu.display == false then
      if foe.drawing == false then
        foe.drawing = true
        foe.position.x = screen_size - 10
        foe.position.y = rnd(128)
        if foe.position.y < ui_height then
          foe.position.y = ui_height + 2
        elseif foe.position.y > screen_size - 2 then
          foe.position.y = screen_size - 5
        end
    else
      if foe.life <= 0 then
        if foe.sprite == 16 then
          foe.sprite = foe.sprite_death_start
        end
        if foe.sprite > 16 and foe.sprite < foe.sprite_death_stop then
          foe.sprite += 1
        end
        if foe.sprite == foe.sprite_death_stop then
          player.score += 1
          reset_foe()
        end
      else
        foe.position.x -= foe.speed
        if foe.position.x <= 0 then
          player.score -= 1
          display_damage = true 
          reset_foe()
          sfx(4)
        end
      end
    end
    rectfill(foe.position.x - 2, foe.position.y - 8, foe.position.x + 11, foe.position.y - 4, 11)
    print(foe.life .. "/" .. foe.max_life, foe.position.x, foe.position.y - 8, 7)
    spr(foe.sprite, foe.position.x, foe.position.y)
  end

  function reset_foe()
    foe.drawing = false
    foe.life = foe.max_life
    foe.sprite = 16
  end
end

-- combat
function is_fireball_foe()
  fireball_ = player.spells.fireball
  fip = fireball_.position
  fp = foe.position
  if fireball_.drawing == true and fip.x >= fp.x and (fip.y < fp.y + 4 and fip.y > fp.y - 4) then
    foe.life -= 1
    fireball_.drawing = false
    player.attacking = false
    sfx(1)
  end
end

function is_foe_player()
  fp = foe.position
  if (player.x < fp.x + 2 and player.x > fp.x - 2) and (player.y < fp.y + 2 and player.y > fp.y - 2) then
    reset_foe()
    player.life -= 1
    display_damage = true
    sfx(4)
  end
end

-- menu
menu = {}
menu.display = false
menu.items = {"+ moving speed", "+ attack speed", "+ tbd"}
menu.selected = 1

function togglemenu()
  menu.selected = 1
  if menu.display == true then
    menu.display = false
  else
    menu.display = true
  end
end

function draw_menu()
  if menu.display == true then
    for i, item in pairs(menu.items) do
      color = 7
      if i == menu.selected then
        color = 2
      end
      print("-> " .. item, 0, (i + 1) * 6, color)
    end
  end
end

function select_menu()
  if menu.selected == 1 and player.score >= 2 then
    player.score -= 2
    old_score = player.score
    player.speed += 0.5
    sfx(3)
  end
  if menu.selected == 2 and player.score >= 2 then
    player.score -= 2
    old_score = player.score
    player.spells.fireball.speed += 0.5
    sfx(3)
  end
end

-- user interface
screen_size = 128
ui_width = screen_size
ui_height= 6
function draw_ui()
  line(0, ui_height, ui_width, ui_height, 7)
  if display_damage == true then
    line(0, ui_height, 0, screen_size, 8)
    display_damage = false
  else
    line(0, ui_height, 0, screen_size, 7)
  end
  line(0, screen_size - 1, ui_width, screen_size - 1, 7)
  print("life: " .. player.life .. "/" .. player.max_life .. " score: " .. player.score .. " time: " .. flr(last_time))
end

function print_centered(str)
  print(str, 64 - (#str * 2), 60) 
end

function reset()
  player.score = 1
  player.spells.fireball.drawing = false
  player.spells.fireball.speed = 3
  player.attacking = false
  player.life = 5
  player.speed = 2
  foe.drawing = false
  foe.speed = 0.1
  gameover = false
  global_timer = 0
end

-- engine
function _init()
  cls()
end

function _update()
  last_time = time()
  player.moving = false
  check_score()
  is_fireball_foe()
  is_foe_player()
  if btnp(4) then
    togglemenu()
  end
  if menu.display == false then
    if btn(0) and player.x > 1 then
      player.x -= player.speed
      move()
    end
    if btn(1) and player.x < screen_size - 2 then
      player.x += player.speed
      move()
    end
    if btn(2) and player.y > ui_height + 2 then
      player.y -= player.speed
      move()
    end
    if btn(3) and player.y < screen_size - 2 then
      player.y += player.speed
      move()
    end
    if btnp(5) then
      player.attacking = true
    else
      player.attacking = false
    end
  end
  if menu.display == true then
    if btnp(5) then
      select_menu()
    end
    if btnp(2) and menu.selected > 1 then
      menu.selected -= 1
      sfx(2)
    end
    if btnp(3) and menu.selected <= 2 then
      menu.selected += 1
      sfx(2)
    end
  end
  if gameover == true and (btnp(5) or btnp(4)) then
    reset()
  end
  if not player.moving then
    player.sprite = 0
  end
end

function _draw()
  cls()
  if gameover == false then
    draw_ui()
    draw_player()
    draw_foes()
    draw_menu()
  else
    print_centered("game over!")
  end
end


__gfx__
0ffff0000ffff0000ffff000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f44f0000f44f0000f44f000000a8900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbb0000bbbb0000bbbb0000aa88aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbaabb00bbaabb00bbaabb00aa88889a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fbbbbf00fbbbbf00fbbbbf00aa888889000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555000055550000555500009a88a9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050050000500c0000c00500000a98a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c00c0000c0000000000c000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08008800080088000800880008008800880088008808888888088888880aaaa8880aaaa8880aaaa8880aaaa88800000888000008000000000000000000000000
808800888088008880880088808800888088008888880888888aaaa888aaaaa888aaaaa888aa0008880000088000000080000000000000000000000000000000
00a00a0008a80a8808a808880aa8aaa8aaa8aaa8aaa8aaa8aaa8aaaaaaa8aaaaaaa8aaaaaaa8000aa008000a0008000000000000000000000000000000000000
00a00a0000a0aa0000a8aa8000a8aa80aa88aa80aa88aa80aa8aaa80aaaaaa80aa000a80aa000000a0000000a000000000000000000000000000000000000000
000000000aa00a0008a0a80a0aa0a80a0aa0a8080aaaa8080aaaaa080aaaaa080a000a0800000a08000000080000000000000000000000000000000000000000
700700707007007070a70a7a70a7087a78a708787aa708787aa70a787aaa0a787aaa0a787a0000087a0000087a00000000000000000000000000000000000000
07707707077077070770770708787887087878870a7878870a7aaa870a7aaa870a7aaa870a700a870a7000870a00000000000000000000000000000000000000
008888800088888000888880088888800888888088888888888888888888aa8a8888aa8a8888aa8a8888aa8a8888000a80000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000011250182501f250000002625031250352503b2503f25031150000000000000000000003825031250252502225023250242502525026250282502a2502c25030250322500000000000000000000000000
00020000032500325003240083500b44003250143500325016450153401145003250083500325009350032500324003250032500324003250032500325003240053500324002240022400c4500a6500365002650
000100001205016050080500b0501e0500f050220501305014050230501405021050140501405013050130501205003050100500d0500a0500305003050030500305000000000000000000000000000000000000
00020000000000000000000064500a4500e45013450174501c4501e4502145025450284502a4502b4502d4502f450304503245033450354503645037450394503a4503b4503b4503d4503d4503e4503e45000000
000500003f5503f5503f5503f5503f5503e5503d5503a550375503455032550305502e5502e5502c5502b5502a550265502555023550225501f5501e5501b5501a5501855013550115500f5500e5500955007550
__music__
00 40424344

