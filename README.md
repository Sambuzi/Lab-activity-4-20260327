# Lab Activity 4 - ARGoS (Multi-Sensor Navigation)

Questo progetto implementa un controller in Lua per un robot `foot-bot` in ARGoS, con comportamento di navigazione basato su campi potenziali:

- attrazione verso una sorgente luminosa;
- repulsione dagli ostacoli rilevati dai sensori di prossimita';
- avanzamento di base (cruise) per evitare stalli.

## Struttura del progetto

- `controller-ms.lua`: logica principale del robot (init, step, reset).
- `vector.lua`: utility per operazioni vettoriali 2D (somma, conversioni polare/cartesiana).
- `test-ms.argos`: configurazione della simulazione (arena, ostacoli, luce, robot, sensori/attuatori).
- `floor.png`: texture del pavimento usata nello scenario.

## Come funziona il controller

Nel ciclo `step()` il robot:

1. calcola un vettore attrattivo verso la luce (`go_to_light()`);
2. calcola un vettore repulsivo dagli ostacoli (`avoid_obstacles()`);
3. somma i vettori con un vettore di crociera;
4. converte il risultato in velocita' lineare e angolare;
5. imposta la velocita' delle ruote differenziali.

Indicatore LED:

- `verde`: traiettoria relativamente allineata;
- `rosso`: forte deviazione angolare (rotazione marcata).

## Requisiti

- ARGoS3 installato con supporto `foot-bot` e Lua controller.
- Ambiente Linux (o equivalente) con accesso al comando `argos3`.

## Esecuzione

Dalla cartella del progetto:

```bash
argos3 -c test-ms.argos
```

Per terminare la simulazione, chiudere la finestra ARGoS o interrompere il processo da terminale.

## Parametri utili da modificare

- In `controller-ms.lua`:
  - `MAX_VELOCITY`: velocita' massima delle ruote;
  - peso repulsivo in `avoid_obstacles()` (`s.value * s.value * 2.0`);
  - vettore di crociera (`cruise_vec`).
- In `test-ms.argos`:
  - posizione/intensita' della luce;
  - numero/disposizione degli ostacoli;
  - posizione iniziale del robot.

