import telethon as tg
from .. import command, module, util


class PurgeModule(module.Module):
    name = "Purge"
    # disabled = True

    db: util.db.AsyncDB

    async def on_load(self) -> None:
        self.db = self.bot.get_db("purge")

    async def on_message(self, event: tg.events.NewMessage.Event) -> None:
        pass

    @command.desc("Simple purge command")
    @command.alias("p")
    async def cmd_purge(self, ctx: command.Context) -> None:
        if not ctx.msg.reply_to_msg_id:
            await ctx.respond("__Reply to a message!__")
            return

        await ctx.respond("Purging...")
        self.log.debug(ctx.msg.id)
        self.log.debug(ctx.msg.reply_to_msg_id)
        messages: list = list(range(ctx.msg.reply_to_msg_id, ctx.msg.id + 1))  # type: ignore
        self.log.info(f"Deleting message(s) in range {messages}")
        await ctx.bot.client.delete_messages(ctx.msg.chat_id, messages)  # type: ignore
        self.log.info(f"Deleted message(s) in range {messages}")
