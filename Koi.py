import antlr4
from KoiLexer import KoiLexer
from KoiListener import KoiListener
from KoiParser import KoiParser


if __name__ == "__main__":
    lexer = KoiLexer(antlr4.FileStream("Koi.koi"))
    stream = antlr4.CommonTokenStream(lexer)
    parser = KoiParser(stream)
    tree = parser.program()

    listener = KoiListener()
    walker = antlr4.ParseTreeWalker()
    walker.walk(listener, tree)
