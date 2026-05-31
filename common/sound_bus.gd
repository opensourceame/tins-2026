extends Node

const POOL_SIZE: int = 8

var _players: Array[AudioStreamPlayer2D]
var _volume_db: float = 0.0
var _cache: Dictionary = {}

func _ready() -> void:
    for i in range(POOL_SIZE):
        var p = AudioStreamPlayer2D.new()
        p.finished.connect(_recycle.bind(p))
        add_child(p)
        _players.append(p)

func set_master_volume(db: float) -> void:
    _volume_db = db

func play(name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
    var path = "res://sounds/%s.mp3" % name
    if not _cache.has(path):
        _cache[path] = load(path)
    play_sfx(_cache[path] as AudioStream, volume_db, pitch_scale)

func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
    var player = _find_available()
    if not player:
        return

    player.stream = stream
    player.volume_db = _volume_db + volume_db
    player.pitch_scale = pitch_scale
    player.play()

func _find_available() -> AudioStreamPlayer2D:
    for p in _players:
        if not p.playing:
            return p
    return null

func _recycle(player: AudioStreamPlayer2D) -> void:
    player.stream = null
