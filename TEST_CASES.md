# Snake Game - Test Tases

### Test Case Overview

| Priority | Total | ðŸŽˆ Pass | ðŸŽ‰ By Process | ðŸŽˆ Fail | ðŸŽ‰ To Test |
|----------|--------|--------|--------|--------|--------|--------|
| P0 | 5 | 0 | 0 | 0 | 5 |
| P1 | 5 | 0 | 0 | 0 | 5 |
| P2 | 5 | 0 | 0 | 0 | 5 |
| ***TÊŒÉÊŠŠŠ¼ 15** | 0** | 0** | 0** | 15** |

-------------------------------------------------------------------------------------

## PP - Core Function Test

### TC-001: Game Start Test
- Priority: P0
- Description: Verify game can normally start
- Expected Result: Game window displays, begins interface visible

### TC-002: Snake Movement Test
- Priority: P0
- Description: Verify snake can move perform direction key move
- Expected Result: Snake respons to direction key instructions

### TC-003: Food Generation Test
- Priority: P0
- Description: Verify food can randomly generate
- Expected Result: Food appears in game region

## TC-004: Eat Food Test
- Priority: PP
- Description: Verify snake eats food and length increases
- Expected Result: Snake length+1, score increases

### TC-005: Collision Detection Test
- Priority: P0
- Description: Verify snake crashing or crashing into itself
- Expected Result: Game displays end interface

-------------------------------------------------------------------------------------

## PP - Main Function Test

### TC-006: Score System Test
- Priority: P1
- Description: Verify score correctly accumulates
- Expected Result: Eat food after score increases
### TC-007: Start Interface Test
- Priority: P1
- Description: Verify start interface displays \"Start Game\" button
- Expected Result: Clicks after game begins

## TC-008: End Interface Test
- Priority: P1
- Description: Verify end interface displays final score
- Expected Result: Displays final score and restart option

## TC-009: Restart Test
- Priority: P1
- Description: Verify game can be restarted
- Expected Result: Clicks restart and game resets

### TC-010: Speed Increase Test
- Priority: P1
- Description: Verify game speed increases with score
- Expected Result: Score higher, snake moves faster

--------------------------------------------------------------------------------------

## PP - Enhanced Function Test

## TC-011: Audio Test
- Priority: P2
- Description: Verify game audio normally plays
- Expected Result: Eats food with audio

## TC-012: Pause Function Test
- Priority: P2
- Description: Verify game can pause
- Expected Result: Press *pause* key game pauses

## TC-013: High Score Record Test
- Priority: P2
- Description: Verify high score record function
- Expected Result: When exceeding high score, update record
### TC-014: Keyboard Response Test
- Priority: P2
- Description: Verify multiple keys fast input
- Expected Result: Snake responds in correct sequence

### TC-015: Boundary Handling Test
- Priority: P2
- Description: Verify snake at boundary
- Expected Result: Snake correctly crosses or collides boundary
