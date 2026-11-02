# nixos/users/fish.nix

{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "ls -l";
      fuckoff = "shutdown now";
    };

    interactiveShellInit = ''
      pay-respects fish --alias thefuck | source
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      command_timeout = 4000;
      add_newline = false;

      format = ''
        [╭─](bold red)$username$directory$git_branch$git_status$git_metrics$nodejs$package$time
        [╰─](bold red)$character'';

      cmd_duration = {
        format = "took [$duration]($style) ";
      };

      directory = {
        truncate_to_repo = true;
        style = "bold cyan";
      };

      git_branch = {
        symbol = " ";
        style = "bold bright-purple";
        format = "($style)[$symbol]($style)[$branch]($style) ";
      };

      git_status = {
        style = "bright-red";
      };

      git_metrics = {
        disabled = false;
        added_style = "green";
        deleted_style = "red";
        format = "(\\[([+$added]($added_style))([-$deleted]($deleted_style))\\])";
      };

      nodejs = {
        disabled = false;
        style = "green";
        symbol = " ";
      };

      package = {
        disabled = false;
        display_private = true;
        symbol = " ";
        style = "bold green";
      };

      time = {
        disabled = false;
        style = "bold yellow";
      };

      username = {
        disabled = false;
        show_always = true;
        format = "[ $user]($style)";
        style = "bold green";
      };

      aws.symbol = " ";
      docker_context.symbol = " ";
      memory_usage.symbol = " ";

      python = {
        symbol = " ";
        detect_files = [
          ".python-version"
          "Pipfile"
          "__init__.py"
          "pyproject.toml"
          "requirements.txt"
          "setup.py"
          "app.py"
        ];
      };

      rust.symbol = " ";
    };
  };
}

