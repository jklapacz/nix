/**
 * Colorized status bar extension — shows token usage and cost in the footer.
 *
 * Auto-enables on every session.  Toggle with /status-bar.
 *
 * Displays:
 *   ↑ input   ↓ output   R cache-read   W cache-write   CH cache-hit %
 *   💰 cost   context%/window (auto)   │   model (branch)
 *
 * Colors: input=accent, output=success, cache=muted, cost=warning,
 *         context=default (warning >70%, error >90%), model=dim, branch=muted
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

/** Auto-compaction is on unless disabled in ~/.pi/agent/settings.json. */
function isAutoCompactEnabled(): boolean {
  try {
    const path = join(homedir(), ".pi", "agent", "settings.json");
    if (!existsSync(path)) return true;
    const settings = JSON.parse(readFileSync(path, "utf8"));
    return settings?.compaction?.enabled !== false;
  } catch {
    return true;
  }
}

function makeFooter(ctx: ExtensionContext) {
  const autoCompact = isAutoCompactEnabled();

  return (tui: any, theme: any, footerData: any) => {
    const unsub = footerData.onBranchChange(() => tui.requestRender());

    return {
      dispose: unsub,
      invalidate() {},
      render(width: number): string[] {
        // Aggregate token usage across all assistant messages
        let input = 0;
        let output = 0;
        let cacheRead = 0;
        let cacheWrite = 0;
        let cost = 0;
        let latestHitRate: number | undefined;
        for (const e of ctx.sessionManager.getBranch()) {
          if (e.type === "message" && e.message.role === "assistant") {
            const m = e.message as AssistantMessage;
            input += m.usage.input;
            output += m.usage.output;
            cacheRead += m.usage.cacheRead;
            cacheWrite += m.usage.cacheWrite;
            cost += m.usage.cost.total;
            const prompt = m.usage.input + m.usage.cacheRead + m.usage.cacheWrite;
            latestHitRate = prompt > 0 ? (m.usage.cacheRead / prompt) * 100 : undefined;
          }
        }

        const fmt = (n: number): string => {
          if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
          if (n >= 1_000) return `${(n / 1_000).toFixed(1)}k`;
          return String(n);
        };

        const fmtCost = (n: number): string => {
          if (n >= 10) return `$${n.toFixed(2)}`;
          if (n >= 1) return `$${n.toFixed(3)}`;
          if (n >= 0.01) return `$${(n * 100).toFixed(1)}¢`;
          return `$${n.toFixed(4)}`;
        };

        // Build left side (token stats)
        const leftParts: string[] = [];
        if (input > 0 || output > 0) {
          leftParts.push(theme.fg("accent", `↑${fmt(input)}`));
          leftParts.push(theme.fg("success", `↓${fmt(output)}`));
        }
        if (cacheRead > 0) {
          leftParts.push(theme.fg("muted", `R${fmt(cacheRead)}`));
        }
        if (cacheWrite > 0) {
          leftParts.push(theme.fg("muted", `W${fmt(cacheWrite)}`));
        }
        if ((cacheRead > 0 || cacheWrite > 0) && latestHitRate !== undefined) {
          leftParts.push(theme.fg("muted", `CH${latestHitRate.toFixed(1)}%`));
        }
        if (cost > 0) {
          leftParts.push(theme.fg("warning", `💰${fmtCost(cost)}`));
        } else if (input > 0 || output > 0) {
          leftParts.push(theme.fg("dim", "💰—"));
        }

        // Context usage: percent of the model's context window
        const usage = ctx.getContextUsage();
        const window = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
        if (window > 0) {
          const auto = autoCompact ? " (auto)" : "";
          const pct = usage?.percent;
          const text =
            pct === null || pct === undefined
              ? `?/${fmt(window)}${auto}`
              : `${pct.toFixed(1)}%/${fmt(window)}${auto}`;
          const color = pct !== null && pct !== undefined && pct > 90
            ? "error"
            : pct !== null && pct !== undefined && pct > 70
              ? "warning"
              : "dim";
          leftParts.push(theme.fg(color as any, text));
        }
        const left = leftParts.join(" ");

        // Right side (model + branch)
        const branch = footerData.getGitBranch();
        const modelName = ctx.model?.id ?? "—";
        const right =
          theme.fg("dim", modelName) +
          (branch ? " " + theme.fg("muted", `(${branch})`) : "");

        const gap = " ".repeat(
          Math.max(1, width - visibleWidth(left) - visibleWidth(right)),
        );
        return [truncateToWidth(left + gap + right, width, "")];
      },
    };
  };
}

export default function (pi: ExtensionAPI) {
  let enabled = true;

  // Install the footer on every session start (covers new, resume, reload, fork).
  pi.on("session_start", async (_event, ctx) => {
    if (enabled) {
      ctx.ui.setFooter(makeFooter(ctx));
    }
  });

  // Toggle on/off via /status-bar
  pi.registerCommand("status-bar", {
    description: "Toggle the colorized status bar showing token usage & cost",
    handler: async (_args, ctx) => {
      enabled = !enabled;

      if (enabled) {
        ctx.ui.setFooter(makeFooter(ctx));
        ctx.ui.notify("Status bar enabled", "info");
      } else {
        ctx.ui.setFooter(undefined);
        ctx.ui.notify("Default footer restored", "info");
      }
    },
  });
}
