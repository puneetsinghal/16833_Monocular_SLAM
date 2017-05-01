snake = HebiLookup.newConnectedGroupFromName('*', 'SA008')

snakeType = 'SEA Snake';
numModules = snake.getInfo.numModules;

snakeData = setupSnakeData( snakeType, numModules);
snakeData.firmwareType = snake.getInfo.firmwareType;

