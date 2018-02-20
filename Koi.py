import antlr4
from KoiLexer import KoiLexer
from KoiListener import KoiListener
from KoiParser import KoiParser


class KoiWalker(KoiListener):
    def __init__(self):
        self.ind = " " * 4

    def enterPrint_stmt(self, ctx:KoiParser.Print_stmtContext):
        print(f"Print: {ctx.getText()}")

    def enterAsstmt(self, ctx:KoiParser.AsstmtContext):
        print(f"Assignment {ctx.getText()}:")

    def enterExpression(self, ctx:KoiParser.ExpressionContext):
        print(f"Expression: {ctx.getText()}")

    def enterArith_expr(self, ctx:KoiParser.Arith_exprContext):
        print(f"{self.ind}Arith Expression: {ctx.getText()}")

    def enterCompa_expr(self, ctx:KoiParser.Compa_exprContext):
        print(f"{self.ind}Compa Expression: {ctx.getText()}")


if __name__ == "__main__":
    lexer = KoiLexer(antlr4.FileStream("Koi.koi"))
    stream = antlr4.CommonTokenStream(lexer)
    parser = KoiParser(stream)
    tree = parser.program()

    listener = KoiWalker()
    walker = antlr4.ParseTreeWalker()
    walker.walk(listener, tree)
