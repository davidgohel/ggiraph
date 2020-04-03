import ggiraphjs from './js/ggiraphjs';
import './css/styles.css';

export function newgi(containerid){
    const ggobj = new ggiraphjs(containerid);
    return ggobj;
}
