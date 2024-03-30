git clone --bare https://github.com/kyedavey/.dotfiles.git $HOME/.dotfiles
mkdir -p .dotfiles-backup
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
else
  echo "Backing up pre-existing dot files.";
  git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi;
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config status.showUntrackedFiles no
