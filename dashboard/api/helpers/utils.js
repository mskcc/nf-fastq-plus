/**
 * Returns value for field if field exists. Otherwise, returns None
 *
 * @param obj
 * @param field
 * @returns {*}
 */
exports.safe_get = function(obj, field){
    if(field[obj] !== null){
        return obj[field];
    }
    return null;
};
