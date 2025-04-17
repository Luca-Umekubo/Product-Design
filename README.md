# Chaos DodgeBall

Fast-paced, first-person team dodgeball chaos with unique characters and abilities and quick reaction events.

## about the game

Imagine a party pvp minigame meets a first person shooter meets dodgeball. this game is a fast paced multiplayer dodgeball fighter/shooter set on a raised platform in a neon lit arena where you have to time dodges, choose and use abilities, and collect powerups to eliminate the other team. the game focuses on fluid and fun movement while trying to capture the fun/frustration of a party game as well as the competetiveness of a first person shooter like overwatch, halo, splitgate, or krunker. the target audience is any casual or competetive gamer that likes the feeling of fast paced first person shooter games with quick and responsive movement. it should be really fun to play/motivating to win and the mechanics should feel rewarding and engaging. Main game mode is a quick (3 minute) best 2/3 deathmatch where a team gets a point if they wipe out or have more players by the end of time than the other team. Tied @ end of regulation triggers overtime where stage starts deteriorating.

## features basic overview

- first person perspective
- fluid movement, making a responsive and quick game
- multiplayer (1v1, 2v2, 3v3, 4v4) dodgeball
- unique character abilities
- charged ultimate ability/throw
- quick time event inspired showdown dodge feature
- slow mo replays and highlights like rocket league or overwatch, enhancing competetive vibe and gloating opportunity
- powerups for added chaos and chance for tables to turn
- varied maps with moving features like super smash bros -- different map pools for more competitive modes
- optional vanilla or powered modes

## gameplay

- players spawned on opposite ends of a raised platform above a void in a large neon lined arena.
  - teams: There will be a line in the middle between the two teams with balls starting spawned on the line
  - single: everyone spawns in a seperate place around the edge of the arena, hunger games style, with balls in the middle.
- each player has 2 lives, which are lost by being hit with a ball. After they are lost, they are out and spectate. Spectators are placed on an invisible platform around the arena which they can walk around and watch the game. If a ball bounces off the platform and a spectating player catches the ball, they are spawned back into a corner of the arena with 1 life.
- a few balls (half of the total amount of players in the game) start in the center of the field, and a timer at the top of the screen counts down to start the game. Once players pickup a ball they have to wait 2 seconds before they can start to throw it.
- when a player has a ball, they can either quick throw, a throw with less speed and accuracy, or go into an aiming state described below.
- when a player has a ball, they can go into an aiming state either from the ground or mid jump. if in the air, pause in the air where they are, hovering, if on the ground, movement speed reduced (more suseptible to enemy throws). this aiming state gives a chace for the players on the other side to anticipate the throw and try to dodge it. the player throwing can pump fake to try and draw out a dodge and the player dodging has a dodge left right, duck or jump on a cooldown, so they have to anticipate a throw vs a pump fake.
- after balls are thrown, they will bounce around the ground of the arena, but if one falls off the side of the arena, it will respawn in the center.
- players can catch incoming balls but it requires a high skill quicktime event that grants the 'catch' passive or stuns them. The quicktime is a randomly strewn set of targets to click, the lower the player's catching skill, the greater the range of targets. If someone fails to catch the ball, they will be stunned for .5 seconds (enough to be hit by ball). If the player suceeds, they gain the 'catch' skill for the next .5 seconds, to catch a ball they must get hit by the ball while their crosshair is looking at it. Even with the 'catch' skill activated, if a player is hit with their crosshair off the ball, they will be out
- if a player on your team gets hit by a ball or blocks an incoming ball with their own, it will fly in a random direction and slow down, you can catch it with the standard skill to keep the hit player in and the thrown player to lose a life. catching a ball also gives one life back to an out player (first player to get out) or the lowest health player on the team.
- at 2 times, a third and to thirds way through the game, a powerup will spawn on the centerline and if a player hits it with a ball or touches it physically, it will activate for the team. (any of the random powerups)
- teams/players also cannot horde balls, and they will go to the other team if held too long. (if more than 80% of the balls are on one side for 10 seconds it will spawn but in the middle of the other side of the arena nearest the enemy team)
- dodgeballs also have a bit of knockback, so they can push an enemy off the stage to immediately eliminate both their lives

## interface

- timer in top middle with player counts on each side of the time for each team.
- Underneath the timer is the amount of lives that you have (2 hearts minecraft style and if you lose one then that heart becomes blacked out)
- On the top left hand side there is an opaque board with all your teammates profile pictures and the amount of lives they have left next to them.
- At very bottom of screen is your ultimate ability charge bar.

## Power system

- players can choose between three characters, each with a unique power and the same ultimate throw that charges up .
  - ultimate throw: ultimate ability that charges after x amount of hits, and can be activated by holding the throw button for 0.5 seconds like smash bros or overwatch, giving their next throw even faster speed (This speed will be shown by a flaming ball) and double the time in the aim state(Giving you twice as long to aim and throw your ultimate). This throw also has double the knockback and can knock players off the stage more easily.
  - character 1: architect
    - can summon temporary walls to hide behind for a few seconds with a long cooldown
    The architect can spawn a 2 by 2 grid blocked wall, that gets destroyed when It gets hit by an ultimate dodgeball or by 3 regular dodgeball hits.
  - character 2: trickster
    - can go invisible and create a decoy in their place that goes into the aim animation. The decoy has the exact same skin and lasts for 7 seconds, throwing two fake dodgeballs before it fades into nothingness and the real player is revealed. This has a long cooldown as well
  - character 3: agressor
    - ability to set ball on fire, leaving a temporary trail of flames on the ground wherever the ball is thrown that doesnt do damage but players cannot cross and will be knocked back from it, creating a way for the agressor to crowd/herd the enemy team. fire ball also does more knockback with an explosion doing splash knockback.
    - ultimate throw: ultimate ability that charges up over a while and can be activated like smash bros or overwatch, giving their next throw even faster speed (visualized by on fire ball) and more time in the aim state. this throw also has much more knockback and can knock players off the stage more easily.
    - character 1: architect
      - can summon temporary walls to hide behind for a few seconds with a long cooldown
    - character 2: trickster
      - can go invisible and create a decoy in their place that goes into the aim animation.
      - can set a spin to any ball they throw by adjusting a point placed on a ball picture (similar to 8 ball mobile game)
    - character 3: agressor
      - ability to set ball on fire, leaving a temporary trail of flames on the ground wherever the ball is thrown that doesnt do damage but players cannot cross and will be knocked back from it, creating a way for the agressor to crowd/herd the enemy team. fire ball also does more knockback with an explosion doing splash knockback.

## powerups
Powerups appear as floating items that are randomly spawned around the map, making sure to be evenly placed on either side(one on your side one on the other side)

- time slow:
  - when collected, a 10 second period starts where the other team's movement and thrown balls will be slower. The team's thrown balls will decrease by 20% speed and their movement decreases by 15%
- hunt:
  - when collected, each player on that team gets a player on the other team to "hunt" for a certain amount of time. if they hit their target, their targets lives go to zero. Their targets will be shown on their screen and above their heads so the opposing team can see who is hunting who. This powerup lasts for 10 seconds.
- golden ball:
  - when collected, a for 5 seconds, the balls turn golden and immediatley do full health damage instead of one life 
- ballstorm:
  - when collected, a rain of dodgeballs spawns on your side of the arena, which can be picked up by your team and will not damage you when it falls from the sky, all created balls despawn after 15 seconds
- firechain:
  - any hit from your team causes a mini-explosion that can damage anyone in a small radius around the hit player for 30 seconds.

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

## Extra Ideas:

-Graveyard Zone: when a player dies, they respawn on a thin straight platform behind their teammates where the catching ability has no cooldown. The platform should stretch the entire back side of both ends and should be wide enough for 4 steps. If they can catch a ball that is flying off the map, they respawn back into the game. The graveyard zone should be surrounded by invisible walls so the dead player cannot fall off or couldn't influence the game with abilities but, dodgeballs should pass though the barrier to be caught. Apart from physically restraining the player, the gameplay in the graveyard zone should be identical to standard play (abilities, movement, ect. are all used normally). 
-Balls will fall off the map and respawn in the middle once they hit a zone below the map
-Players ragdoll when they get hit and have an animation upon death that can be changed by the dead player with skins(fireworks, skull, ghost, ect.)
-Stage Progression. During overtime, the platform starts crumbling and shrinking, making it harder to dodge balls and making players more wary of their own steps. The dimentions of the stage shrink 5% every 30 seconds with a minimum size of 10% of original dimentions.

> > > > > > > origin/BjornBranch

-Curveball techniques: The spin/curve of the ball can be changed before the ball is thrown using joystick/arrow keys can create curving spins for more unique shots. The player can press a button to enable spin editing and it will be visualized by moving a dot on a dodgeball in the bottom right corner. The dot at the bottom will be backspin, left will be left-spin, ect. The dot will be able to move in 2 dimensions so angular spin is possible (45 degrees, 128 degrees, ect.) The ball will curve in the air based on the spin, leading to enable hitting people around corners and more difficult catches. The spin will not be reflected in the crosshair so the player must approximately adjust based on the spin they set


-Cosmetics: 
  Ball trails, default goes from yellow to red based on the speed of the ball, fire and ice skins can be purchased. They linger for a bit then go away.
  Death animations, default is blank but players can add fireworks that explode upon death, a ghost that comes out of their corpse
