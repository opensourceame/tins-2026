extends Node

const POOL_SIZE: int = 8

var _players: Array[AudioStreamPlayer2D] = []
var _volume_db: float = 0.0
var _cache: Dictionary = {}

@export var use_cache: bool = true

func _ready() -> void:
    for i in range(POOL_SIZE):
        var p = AudioStreamPlayer2D.new()
        p.finished.connect(_recycle.bind(p))
        add_child(p)
        _players.append(p)

func set_master_volume(db: float) -> void:
    _volume_db = db

func play(name: String, volume_db: float = 0.0, pitch_scale: float = 1.0, use_cache_override: bool = true) -> void:
    var path = "res://sounds/%s.mp3" % name
    if use_cache and use_cache_override:
        if not _cache.has(path):
            _cache[path] = load(path)
    else:
        _cache.erase(path)
        _cache[path] = load(path)
    var stream = _cache[path] as AudioStream
    print("SoundBus: playing '%s' (path=%s, stream=%s, players=%d/%d)" % [name, path, "null" if stream == null else "ok", _count_available(), _players.size()])
    if stream == null:
        print("SoundBus ERROR: failed to load " + path)
        return
    play_sfx(stream, volume_db, pitch_scale)

func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
    var player = _find_available()
    if not player:
        return

    player.stream = stream
    player.volume_db = _volume_db + volume_db
    player.pitch_scale = pitch_scale
    player.play()

func _count_available() -> int:
    var count = 0
    for p in _players:
        if not p.playing:
            count += 1
    return count

func _find_available() -> AudioStreamPlayer2D:
    for p in _players:
        if not p.playing:
            return p
    return null

func _recycle(player: AudioStreamPlayer2D) -> void:
    player.stream = null
