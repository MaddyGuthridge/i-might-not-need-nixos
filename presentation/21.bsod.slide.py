from slides_xp.themes.xp import make_bsod_slide

INSTRUCTIONS = """
* Thank you for letting me present.
* I hope you found this as interesting and fun as I did.
* Let's do some Q&A, time permitting.
"""


def render():
    return make_bsod_slide(
        "LinSoc Presentation",
        INSTRUCTIONS,
    )
