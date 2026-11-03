
{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "ls -lah";
      fuckoff = "shutdown now";
    };

    interactiveShellInit = ''
      pay-respects fish --alias thefuck | source

      function starship_transient_prompt_func
        starship module character
      end

      function starship_transient_rprompt_func
        :
      end

      enable_transience
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      command_timeout = 4000;
      add_newline = false;

      # Prompt structure
      format = "$username$hostname$directory $fill $all $time$line_break$character";

      # Shell interaction
      character = {
        success_symbol = "[@](bold green)";
        error_symbol = "[@](bold red)";
        vimcmd_symbol = "[@](bold blue)";
      };

      fill = {
        symbol = "─";
        style = "dimmed";
      };

      # Context modules
      username = {
        style_user = "bold blue";
        style_root = "bold red";
        format = "[$user]($style)";
        show_always = false;
      };

      hostname = {
        ssh_only = true;
        style = "blue";
        format = "[@$hostname]($style)";
        disabled = false;
      };

      directory = {
        truncation_length = 4;
        truncate_to_repo = true;
        truncation_symbol = "…/";
        style = "cyan";
        format = "[$path]($style)";
        read_only = " 󰌾";
        read_only_style = "dimmed white";
      };

      shell.disabled = true;

      # Time
      time = {
        disabled = false;
        time_format = "%F %T";
        style = "dimmed white";
        format = "[$time]($style)";
      };

      # Command duration
      cmd_duration = {
        min_time = 10000;
        style = "dimmed white";
        format = "[⏱ $duration]($style)";
      };

      # Git
      git_branch = {
        symbol = "git ";
        style = "yellow";
        format = "[$symbol$branch]($style)";
      };

      git_status = {
        style = "white";
        format = "([$all_status$ahead_behind]($style))";
        conflicted = "≠";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      git_commit = {
        style = "dimmed white";
        format = "[$hash]($style)";
      };

      git_state = {
        style = "dimmed white";
        format = "[$state( $progress_current of $progress_total)]($style)";
      };

      # Language runtimes
      nodejs = {
        symbol = "node ";
        style = "green";
        format = "[$symbol($version )]($style)";
      };

      rust = {
        symbol = "rs ";
        style = "red";
        format = "[$symbol($version )]($style)";
      };

      golang = {
        symbol = "go ";
        style = "cyan";
        format = "[$symbol($version )]($style)";
      };

      python = {
        symbol = "py ";
        style = "yellow";
        format = "[$symbol($version )]($style)";
      };

      # Cloud / DevOps
      aws = {
        symbol = "aws ";
        style = "yellow";
        format = "[$symbol($profile )]($style)";
      };

      gcloud = {
        symbol = "gcp ";
        style = "blue";
        format = "[$symbol($active )]($style)";
      };

      kubernetes = {
        symbol = "k8s ";
        style = "cyan";
        format = "[$symbol($context)]($style)";
      };

      terraform = {
        symbol = "tf ";
        style = "magenta";
        format = "[$symbol($workspace)]($style)";
      };

      # Package management
      package = {
        symbol = "package ";
        style = "yellow";
        format = "[$symbol$version]($style)";
      };

      # System
      jobs = {
        symbol = "⚙ ";
        style = "blue";
        format = "[$symbol$number]($style)";
        threshold = 1;
      };

      memory_usage.disabled = true;
      battery.disabled = true;

      shlvl = {
        style = "dimmed white";
        format = "[$shlvl]($style)";
        threshold = 2;
      };
    };
  };
}

