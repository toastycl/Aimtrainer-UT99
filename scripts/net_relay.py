#!/usr/bin/env python3
"""Single-client localhost UDP latency relay. Adds RTT/2 in each direction.
Only binds/forwards on IPv4 loopback. Does not simulate loss, jitter or bandwidth.
"""
import argparse
import asyncio

class Relay(asyncio.DatagramProtocol):
    def __init__(self, server_port, rtt_ms):
        self.server=('127.0.0.1',server_port)
        self.delay=rtt_ms/2000
        self.client=None
        self.pending=set()
    def connection_made(self, transport):self.transport=transport
    def datagram_received(self, data, addr):
        if addr==self.server:
            if self.client is None:return
            destination=self.client
        elif addr[0]=='127.0.0.1':
            if self.client not in (None,addr):return
            self.client=addr;destination=self.server
        else:return
        loop=asyncio.get_running_loop()
        handle=None
        def deliver():
            self.pending.discard(handle)
            self.transport.sendto(data,destination)
        handle=loop.call_later(self.delay,deliver);self.pending.add(handle)
    def connection_lost(self, exc):
        for handle in self.pending:handle.cancel()
        self.pending.clear()

async def run(listen_port,server_port,rtt_ms):
    transport,_=await asyncio.get_running_loop().create_datagram_endpoint(
        lambda:Relay(server_port,rtt_ms),local_addr=('127.0.0.1',listen_port))
    print(f'Loopback relay 127.0.0.1:{listen_port} -> 127.0.0.1:{server_port}; added RTT={rtt_ms} ms',flush=True)
    try:await asyncio.Future()
    finally:transport.close()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--listen-port',type=int,default=18777);p.add_argument('--server-port',type=int,default=17777)
    p.add_argument('--rtt-ms',type=float,default=100);a=p.parse_args()
    if not 1<=a.listen_port<=65535 or not 1<=a.server_port<=65535 or a.listen_port==a.server_port:p.error('Use distinct valid ports')
    if not 0<=a.rtt_ms<=300:p.error('RTT must be between 0 and 300 ms')
    try:asyncio.run(run(a.listen_port,a.server_port,a.rtt_ms))
    except KeyboardInterrupt:pass
if __name__=='__main__':main()
