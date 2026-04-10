const https = require("https");

const POLL_INTERVAL = parseInt(process.env.POLL_INTERVAL || "30", 10);
const TIMEOUT = parseInt(process.env.TIMEOUT || "1800", 10);
const COORDINATES = process.env.COORDINATES || "";

function buildUrl(groupId, artifactId, version) {
  const groupPath = groupId.replace(/\./g, "/");
  return `https://repo1.maven.org/maven2/${groupPath}/${artifactId}/${version}/${artifactId}-${version}.pom`;
}

function checkAvailable(url) {
  return new Promise((resolve) => {
    const req = https.request(url, { method: "HEAD" }, (res) => {
      resolve(res.statusCode >= 200 && res.statusCode < 400);
    });
    req.on("error", () => resolve(false));
    req.end();
  });
}

function sleep(seconds) {
  return new Promise((resolve) => setTimeout(resolve, seconds * 1000));
}

function parseCoordinates(raw) {
  const coords = [];
  for (const line of raw.split(/[\n\s]+/)) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    const parts = trimmed.split(":");
    if (parts.length !== 3 || !parts[0] || !parts[1] || !parts[2]) {
      console.error(
        `Error: Invalid coordinate '${trimmed}'. Expected format groupId:artifactId:version`
      );
      process.exit(1);
    }
    coords.push({ groupId: parts[0], artifactId: parts[1], version: parts[2], raw: trimmed });
  }
  return coords;
}

async function main() {
  if (!COORDINATES.trim()) {
    console.error("Error: COORDINATES is not set or empty.");
    process.exit(1);
  }

  let pending = parseCoordinates(COORDINATES);

  if (pending.length === 0) {
    console.error("Error: No valid coordinates provided.");
    process.exit(1);
  }

  console.log(`Waiting for ${pending.length} artifact(s) to appear on Maven Central:`);
  for (const coord of pending) {
    console.log(`  - ${coord.raw}`);
  }
  console.log("");

  let elapsed = 0;

  while (pending.length > 0) {
    if (elapsed >= TIMEOUT) {
      console.log("");
      console.error(
        `Error: Timed out after ${TIMEOUT}s. The following artifacts are still not available:`
      );
      for (const coord of pending) {
        console.error(`  - ${coord.raw}`);
      }
      process.exit(1);
    }

    const stillPending = [];

    for (const coord of pending) {
      const url = buildUrl(coord.groupId, coord.artifactId, coord.version);
      if (await checkAvailable(url)) {
        console.log(`  Available: ${coord.raw}`);
      } else {
        stillPending.push(coord);
      }
    }

    pending = stillPending;

    if (pending.length === 0) break;

    console.log(`[${elapsed}s/${TIMEOUT}s] Still waiting for ${pending.length} artifact(s)...`);
    await sleep(POLL_INTERVAL);
    elapsed += POLL_INTERVAL;
  }

  console.log("");
  console.log("All artifacts are available on Maven Central.");
}

main().then(() => process.exit(0)).catch((err) => {
  console.error(err);
  process.exit(1);
});
