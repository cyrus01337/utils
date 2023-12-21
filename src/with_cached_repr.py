__all__ = ("WithCachedReprMeta", "WithCachedReprMixin")


class WithCachedReprMeta(type):
    def __new__(cls, name, bases, attrs):
        if (slots := getattr(cls, "__slots__", None)) and "_cached_repr" not in slots:
            new_slots = (*slots, "_cached_repr")

            setattr(cls, "__slots__", new_slots)

        self = super().__new__(cls, name, bases, attrs)

        if name == "WithCachedRepr":
            return self

        # TODO: Resolve/Explain type: ignore
        cached_repr = repr(self) if self.__class__.__dict__.get("__repr__", None) else f"<{name}>"  # type: ignore

        def __repr__(self):
            return self._cached_repr

        setattr(self, "_cached_repr", cached_repr)
        setattr(self, "__repr__", __repr__)

        return self


class WithCachedReprMixin(metaclass=WithCachedReprMeta):
    pass
