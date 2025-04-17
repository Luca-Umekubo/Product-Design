# Chaos DodgeBall

Fast-paced, first-person team dodgeball chaos with unique characters and abilities and quick reaction events.

## about the game

Imagine a party pvp minigame meets a first person shooter meets dodgeball. this game is a fast paced multiplayer dodgeball fighter/shooter set on a raised platform in a neon lit arena where you have to time dodges, choose and use abilities, and collect powerups to eliminate the other team. the game focuses on fluid and fun movement while trying to capture the fun/frustration of a party game as well as the competitiveness of a first person shooter like overwatch, halo, splitgate, or krunker. the target audience is any casual or competitive gamer that likes the feeling of fast paced first person shooter games with quick and responsive movement. it should be really fun to play/motivating to win and the mechanics should feel rewarding and engaging.

## features basic overview

- first person perspective
- fluid movement, making a responsive and quick game
- multiplayer (1v1, 2v2, 3v3, 4v4) dodgeball
- unique character abilities
- charged ultimate ability/throw
- quick time event inspired showdown dodge feature
- slow mo replays and highlights like rocket league or overwatch, enhancing competitive vibe and gloating opportunity
- powerups for added chaos and chance for tables to turn

## gameplay

- players spawned on a raised platform above a void in a large neon arena
- each player has 2 lives, and after they are lost, they are out and spectate (possiblity to get back in?)
- a few balls (half of players?) start in the center of the field, and a quicktime event determines how fast you can get to the centerline to grab a ball happens at the beginning
- when a player has a ball, they can either quick throw, a throw with less speed, or go into an aiming state described below.
- when a player has a ball, they can go into an aiming state either from the ground or mid jump. if in the air, pause in the air where they are, hovering, if on the ground, movement speed reduced. this aiming state gives a chace for the players on the other side to anticipate the throw and try to dodge it. the player throwing can pump fake to try and draw out a dodge and the player dodging has a dodge left right, duck or jump on a cooldown, so they have to anticipate a throw vs a pump fake.
- after balls are thrown, they dont fly/fall off the arena/platform like players could, instead kept in by an invisible wall that only affects the balls
- players can catch dodgeballs using a special mechanic. When the ball is approaching them, a small dot will appear on their screen. If they are able to flick their mouse to the dot, it allows them to catch the ball. The location of the dot on the screen depends on what part of the player's torso the ball is headed for. A ball headed for the chest will make a dot in the middle of the screen, rendering it easy to catch, whereas towards the extremities will be farther up down or to the side, making it harder to catch.
- at a random time around halfway through the game, a powerup will spawn on the centerline and if a player hits it with a ball or touches it physically, it will activate for the team.
- teams/players also cannot hoard balls, and they will go to the other team if held too long
- dodgeballs also have a bit of knockback, so they can push an enemy off the stage

## interface

- fighting game-like interface with a timer on the top right so the match doesn't go on too long, and the profile pictures/of the players on their team with their number of lives and ultimate ability charge bar underneath
- timer should last for 3-5 minutes dependent on play testing; start with 4 minutes 
- players should be in the top middle, and list players from left to right.


## Power system

- players can choose between three characters, each with a unique power and the same ultimate throw that charges up .
    - ultimate throw: ultimate ability that charges up over a while and can be activated like smash bros or overwatch, giving their next throw even faster speed (visualized by on fire ball and 2x the speed (test)) and more time in the aim state (1.5x to start by test this). this throw also has much more knockback and can knock players off the stage more easily.
    - this knockback is relevant when the user catches or knocks the ball. If the ball hits the user, the user is eliminated. However, if the opposite-sided user catches or knocks the ball, they will also be knocked back, meaning they might get knocked off the map. This should move the user back by the height of 2 players for a catch and by the height of 1 player if the user knocks it. 
    - character 1: architect
        - can summon temporary walls to hide behind for a few seconds with a long cooldown
        - twice the height of the user and 3x the width of the user
        - lasts for 5 seconds
    - character 2: trickster
        - can go invisible and create a decoy in their place that goes into the aim animation.
        - invisible for 10 seconds
    - character 3: aggressor
        - ability to set ball on fire, leaving a temporary trail of flames on the ground wherever the ball is thrown that doesnt do damage but players cannot cross and will be knocked back from it, creating a way for the aggressor to crowd/herd the enemy team. fire ball also does more knockback with an explosion doing splash knockback.
        - the trail of flames lasts for 15 seconds(test this)
        - however, the user gets this ability for 35 seconds(test)
        - The knockback effect is the same as ultimate throw.
        - because this shouldn't look like ultimate throw, the flame on the ball is much smaller, and is only really visualized when it hits the ground ( could also make this ice to make it more visible and obvious)
        - If the explosion hits a player with a splash knockback, this knockback does no damage and should only move the player back by 1 player height length
    - character 4: speedster
        - has the ability to slow down time for any balls headed towards them. The downside of this is that it also slows down the player so that if anyone else throws a ball at them, they are very slow to dodge.
        - Cooldown afterward lasts for 45 seconds. 
        - they can slow down time for 5 seconds.
        - once used, cooldown starts again.

## powerups

- time slow:
  - when collected, a 10 second period starts where the other team's movement and thrown balls will be slower
  - movement 1.5 x slower, thrown balls 1.75 x slower (test)
- hunt:
  - when collected, each player on that team gets a player on the other team to "hunt" for a certain amount of time. if they hit their target, their target's lives go to zero and
  - their targets will be shown on their screen and above their heads so the opposing team can see who is hunting who so they know who to dodge
  - lasts for 25 seconds
- golden ball:
  - when collected, a short period starts where the balls turn golden and immediately do full health damage instead of one life
  - this means that all lives are taken off instead of just one
  - This applies for both teams, not only the team that collects it
  - lasts for 30 seconds
- ballstorm:
  - when collected, a rain of dodgeballs spawns on your side of the arena, all created balls despawn after 15 seconds
- firechain:
    - any hit from your team causes a mini-explosion that can damage anyone in a small radius around the hit player for 30 seconds.
- glock:
    - one person just gets a gun
- hugh:
    - all textures become hugh's face

## arena events

- certain environmental events will trigger after some amount of time at random to make the later game more interesting
- events will be announced with a countdown 5 seconds before they occur so players can prepare
- zero g: gravity will be turned off temporarily, causing players to just freely bounce around in the arena
- trampoline: the arena turns bouncy
- watch your step: parts of the floor get outlined in red before temporarily disappearing shortly after, making it possible for players to fall through.

## other gamemodes??

- battle royale: everyone for themselves, larger arena, some obstacles
- boss battles: everyone is on the same team fighting an AI dodgeball monster
- capture the flag: to win, a team must bring a flag on the opposing side back towards their own side for a certain amount of time without getting out
- ranked mode?

## cosmetics

- emojis? dances? skins?
- perhaps these can be bought with currency from winning games, or they are just given randomly after a game is won

## stats

- players can see how many eliminations they have, how many deaths they have, etc. in their profile in the menu
- after matches are over, an mvp can be crowned, and other titles can be awarded depending on statistics

## Concept images:

### Arena:

![image1](Image1.png)
![image1](Image2.png)
![image1](Image3.png)
![image4](Image4.jpeg)

### POV:

![image4](Image5.jpeg)
![image4](Image6.png)
![image4](Image7.png)

Meaningful Suggestions:
 - ranked mode --> allow players to compete with one another in a more competitive environment, possibly to unlock cosmetics
 - modifiers --> at the start of the round, players should be able to vote for modifiers to spice up the games
 - timed throws --> make it so that players have to time their throws to increase difficulty (like green timing in 2k). Different characters have diffent timings. Timing affects accuracy and speed of throws
 - catching/knocking balls --> this would be a fun feature that could be implemented by giving users a short time frame and a small target that players would have to click on to be able to catch/knock balls. Knocking would have a slightly larger target.

 Less-Meaningful Suggestions:
 - add cosmetics like skins, emotes, taunts, victory/loss animations, kill animations, icons, etc.
 - new powerup --> lets users push the barrier closer to the opponents, allowing them to get closer to their opposition
 - add rotating arenas to improve the ambiance of the game
