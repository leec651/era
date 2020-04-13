# Boilerplate for a MEVN+ project

## Setup
Install and configure mongodb, the main data storage and also used as session storage. Consider using [mongod.conf](https://docs.mongodb.com/manual/reference/configuration-options/)
```
brew install mongodb
mkdir -p ~/data/db
mongod='mongod --dbpath ~/data/db'
```

Install node and npm
```
brew install node npm
```

(optional) Install coffeescript 2
```
npm install coffeescript -g
```

Install all node dependencies
```
npm install
```

## Development
Compiles and hot-reloads for development
```
npm run serve
```

Start development express nodemon
```
npm run dev
```

## Production
Compiles and minifies for production
```
npm run build
```

Start production express service
```
npm run start
```

