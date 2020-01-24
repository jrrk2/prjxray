import os
import random
random.seed(int(os.getenv("SEED"), 16))
from prjxray import util
from prjxray import verilog
from prjxray.db import Database


def gen_sites():
    db = Database(util.get_db_root(), util.get_part())
    grid = db.grid()
    for tile_name in sorted(grid.tiles()):
        gridinfo = grid.gridinfo_at_tilename(tile_name)
        for site_name, site_type in gridinfo.sites.items():
            if site_type in ['PLLE2_ADV']:
                yield tile_name, site_name


def write_params(params):
    pinstr = 'tile,val,site\n'
    for tile, (site, val) in sorted(params.items()):
        pinstr += '%s,%s,%s\n' % (tile, val, site)
    open('params.csv', 'w').write(pinstr)


def run():
    print('''
module top();
    ''')

    params = {}
    # FIXME: can't LOC?
    # only one for now, worry about later
    sites = list(gen_sites())
    for (tile_name, site_name), isone in zip(sites,
                                             util.gen_fuzz_states(len(sites))):
        params[tile_name] = (site_name, isone)

        print(
            '''
    (* KEEP, DONT_TOUCH,  LOC = "{site_name}" *)
    PLLE2_ADV #( .STARTUP_WAIT({isone}) ) dut_{site_name} ();
'''.format(
                site_name=site_name,
                isone=verilog.quote('TRUE' if isone else 'FALSE'),
            ))

    print("endmodule")
    write_params(params)


if __name__ == '__main__':
    run()
