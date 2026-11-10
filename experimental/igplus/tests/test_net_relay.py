import asyncio
import importlib.util
from pathlib import Path
import time
import unittest
spec=importlib.util.spec_from_file_location('net_relay',Path(__file__).resolve().parents[1]/'scripts'/'net_relay.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)

class Echo(asyncio.DatagramProtocol):
    def connection_made(self,transport):self.transport=transport
    def datagram_received(self,data,addr):self.transport.sendto(data,addr)
class Receiver(asyncio.DatagramProtocol):
    def __init__(self,future):self.future=future
    def datagram_received(self,data,addr):
        if not self.future.done():self.future.set_result(data)

class RelayTest(unittest.IsolatedAsyncioTestCase):
    async def test_round_trip_adds_delay_and_preserves_payload(self):
        loop=asyncio.get_running_loop();transports=[]
        try:
            server,_=await loop.create_datagram_endpoint(Echo,local_addr=('127.0.0.1',0));transports.append(server)
            relay,_=await loop.create_datagram_endpoint(lambda:module.Relay(server.get_extra_info('sockname')[1],100),local_addr=('127.0.0.1',0));transports.append(relay)
            result=loop.create_future()
            client,_=await loop.create_datagram_endpoint(lambda:Receiver(result),local_addr=('127.0.0.1',0));transports.append(client)
            started=time.monotonic();client.sendto(b'UT99-payload',relay.get_extra_info('sockname'))
            self.assertEqual(await asyncio.wait_for(result,3),b'UT99-payload')
            self.assertGreaterEqual(time.monotonic()-started,0.095)
        finally:
            for transport in transports:transport.close()
