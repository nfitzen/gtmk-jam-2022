# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 nfitzen, daatguy, UnrelatedString

extends AudioStreamPlayer

func _on_Sound_finished():
    queue_free();
