import discord
import os
import websockets
import asyncio
from concurrent.futures import ThreadPoolExecutor
from threading import Thread
from discord.ext import commands

settings = {
	'bot_token': '', #!!!
	'bot_name': 'interbot',
	'bot_client_id': 0, #!!!
	'prefix': '~',
    'separator': '@#$',
    'channel_id': 0, #!!!
    'ip': '',
    'port': 0
}

intents = discord.Intents.all()
bot = commands.Bot(command_prefix=settings['prefix'], intents=intents)
mmmssg = None

@bot.event
async def on_message(message):
    sender = message.author
    if sender.bot:
        return
    global mmmssg
    if message.channel.id == settings['channel_id']:
        mmmssg = sender.name + settings['separator'] + message.content

@bot.event
async def on_ready():
    print("GDiscord bot is ready!")
    wsock = Thread(target=start_loop, args=(new_loop, start_server))
    wsock.start()

async def handle_integration(websocket, path):
    global mmmssg
    while True:
        await asyncio.sleep(0.1)
        if mmmssg:
            await websocket.send(mmmssg)
            mmmssg = None

new_loop = asyncio.new_event_loop()
start_server = websockets.serve(handle_integration, settings['ip'], settings['port'], loop = new_loop)

def start_loop(loop, server):
    loop.run_until_complete(server)
    loop.run_forever()

bot.run(settings['bot_token'])