// Inextensible cylindrical cross-section: integrate the tangent along the
// paper, rather than rotate a flat rectangle. End states are exactly flat.
function clamp(x, lo, hi) { return Math.max(lo, Math.min(hi, x)); }

function point(u, p, direction, bendY) {
    const curl = 1.45 * Math.sin(Math.PI * p);
    const angle = Math.PI * p - curl / 2;
    const theta = angle + curl * u;
    const x = curl < 0.00001 ? u * Math.cos(angle)
                            : (Math.sin(theta) - Math.sin(angle)) / curl;
    const z = curl < 0.00001 ? u * Math.sin(angle)
                            : (Math.cos(angle) - Math.cos(theta)) / curl;
    return { x: 768 + direction * 611 * x,
             y: -0.22 * 611 * z + bendY * u * Math.sin(Math.PI * p),
             z: 611 * z, normal: Math.cos(theta) };
}

function paint(ctx, right, left, p, direction, bendY) {
    const strips = [];
    const count = 160;
    for (let i = 0; i < count; ++i) {
        const a = point(i / count, p, direction, bendY);
        const b = point((i + 1) / count, p, direction, bendY);
        strips.push({ i: i, a: a, b: b, depth: (a.z + b.z) / 2 });
    }
    // Cast a broad shadow beneath the raised sheet.
    ctx.save();
    ctx.beginPath();
    ctx.moveTo(768, 70);
    for (let i = 0; i <= count; ++i) {
        const v = point(i / count, p, direction, bendY);
        ctx.lineTo(v.x + 0.08 * v.z, 70 + 0.05 * v.z);
    }
    for (let i = count; i >= 0; --i) {
        const v = point(i / count, p, direction, bendY);
        ctx.lineTo(v.x + 0.08 * v.z, 930 + 0.05 * v.z);
    }
    ctx.closePath();
    ctx.fillStyle = "rgba(30,15,3," + (0.22 * Math.sin(Math.PI * p)) + ")";
    ctx.shadowColor = "#231306";
    ctx.shadowBlur = 22 * Math.sin(Math.PI * p);
    ctx.fill();
    ctx.restore();

    strips.sort(function(a, b) { return a.depth - b.depth; });
    for (let j = 0; j < strips.length; ++j) {
        const s = strips[j];
        const normal = (s.a.normal + s.b.normal) / 2;
        const side = normal >= 0 ? direction : -direction;
        const texture = side === 1 ? right : left;
        const sw = 611 / count;
        const sx = side === 1 ? 768 + s.i * sw : 768 - (s.i + 1) * sw;
        const start = side === 1 ? s.a : s.b;
        const end = side === 1 ? s.b : s.a;
        if (Math.abs(end.x - start.x) < 0.0001) continue;
        ctx.save();
        ctx.transform((end.x - start.x) / sw, (end.y - start.y) / sw,
                      0, 1, start.x, start.y);
        // A small overlap suppresses subpixel cracks between adjacent strips.
        ctx.drawImage(texture, sx, 0, sw, 1024, -0.12, 0, sw + 0.24, 1024);
        // Preserve the alpha silhouette, including the irregular paper edge.
        ctx.globalCompositeOperation = "source-atop";
        ctx.fillStyle = "rgba(48,25,7," + (0.28 * (1 - Math.abs(normal))) + ")";
        ctx.fillRect(-0.12, 0, sw + 0.24, 1024);
        ctx.restore();
    }
}
