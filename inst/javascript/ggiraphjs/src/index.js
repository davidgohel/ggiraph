import ggiraphjs from './js/ggiraphjs';

export function newgi(containerid){
    const ggobj = new ggiraphjs(containerid);
    return ggobj;
}
