import axios from 'axios';
import { BACKEND } from '../config';

const getData = (resp) => {
    const wrapper_data = resp.data || {};
    const data = wrapper_data.data;
    return data;
};

/**
 * Reterieves the nextflow pipeline events for the input run name
 *
 * @param runName
 * @returns {Promise<AxiosResponse<T>>}
 */
export function getEvents(runName) {
    return axios
        .get(`${BACKEND}/api/nextflow/get-pipeline-update?run=${runName}`)
        .then(resp =>  getData(resp))
        .catch(error => {throw new Error('Unable to get Get Events: ' + error); });
}

/**
 * Retrieves the sequencing runs from the input number of days
 * @returns {Promise<AxiosResponse<T>>}
 */
export function getSequencingRuns(numDays = 7) {
    return axios
        .get(`${BACKEND}/api/nextflow/recent-runs?days=${numDays}`)
        .then(resp =>  getData(resp))
        .catch(error => {throw new Error('Unable to get Get Events: ' + error); });
}
