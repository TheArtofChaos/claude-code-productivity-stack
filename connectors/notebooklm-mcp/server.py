"""Thin local MCP wrapper around the notebooklm CLI, so Cowork / Claude Desktop
can list, query, create, and add sources to NotebookLM. Auth is handled by the
CLI (storage_state + the NotebookLM-KeepAlive task). On an auth error it returns a
message telling you to run `notebooklm login` — it does NOT open a browser itself."""
import shutil
import subprocess
from fastmcp import FastMCP

NB = shutil.which("notebooklm") or r"C:\Python314\Scripts\notebooklm.exe"
mcp = FastMCP("notebooklm")


def _run(args, timeout=300):
    try:
        r = subprocess.run([NB] + args, capture_output=True, text=True, timeout=timeout)
    except Exception as e:
        return f"error running notebooklm: {e!r}"
    out = (r.stdout or "").strip()
    if r.returncode != 0:
        err = (r.stderr or "").strip()
        if "auth" in err.lower() or "login" in err.lower():
            return "NotebookLM auth expired — run `notebooklm login` in a terminal, then retry. " + err[:300]
        return out + ("\n[stderr] " + err if err else "") or f"(exit {r.returncode})"
    return out or "(ok)"


@mcp.tool
def list_notebooks() -> str:
    """List all NotebookLM notebooks as JSON (id, title, etc.)."""
    return _run(["list", "--json"])


@mcp.tool
def ask(question: str, notebook_id: str) -> str:
    """Ask a question against a NotebookLM notebook; returns a synthesized answer with citations."""
    _run(["use", notebook_id], timeout=60)
    return _run(["ask", question])


@mcp.tool
def create_notebook(title: str) -> str:
    """Create a new NotebookLM notebook; returns JSON including its id."""
    return _run(["create", title, "--json"])


@mcp.tool
def add_source(path_or_url: str, notebook_id: str) -> str:
    """Add a source (local file path or URL) to a NotebookLM notebook."""
    return _run(["source", "add", path_or_url, "--notebook", notebook_id, "--json"])


if __name__ == "__main__":
    mcp.run()
