const winston = require('winston');

const { format } = winston;
const { constants } = require('./constants');

const logLabel = constants.logger;
const container = new winston.Container();

const fileConfig = format.combine(
    format.timestamp({
        format: 'YYYY-MM-DD HH:mm:ss',
    }),
    format.json()
);

const consoleConfig = format.combine(
    format.colorize(),
    format.align(),
    format.timestamp({
        format: 'YYYY-MM-DD HH:mm:ss',
    }),
    format.printf((info) => `${info.timestamp} ${info.level}: ${info.message}`)
);

container.add(logLabel, {
    format: fileConfig,
    transports: [
        new winston.transports.File({ filename: `${logLabel}_error.log`, level: 'error' }),
        new winston.transports.File({ filename: `${logLabel}_combined.log` }),
    ],
});

// nicely log to console for dev
if (process.env.NODE_ENV === 'production') {
    container.get(logLabel).add(
        new winston.transports.Console({
            format: consoleConfig,
        })
    );
}

exports.logger = container.get(logLabel);
