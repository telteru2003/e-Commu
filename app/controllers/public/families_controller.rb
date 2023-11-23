class Public::FamiliesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy, :memberships]
  before_action :set_family, only: [:show, :edit, :update, :memberships, :permit, :destroy]
  before_action :set_user

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)
    @family.owner_id = current_user.id

    if @family.save
      @user.family = @family
      @user.save
      flash[:notice] = "グループを作成しました"
      redirect_to show_user_path(@user)
    else
      flash[:alert] = "エラーによりグループを作成できません"
      render 'new'
    end
  end

  def show
    @users = @family.users
    @owner = @family.owner
  end

  def edit
    @family.places.build # 新しい保管場所のフォームを表示するために追加
    @places = Place.all
    @place = Place.new
  end

  def update
    if @family.update(family_params)
      flash[:notice] = "グループ情報を更新しました"
      redirect_to family_path(@family)
    else
      flash[:alert] = "エラーによりグループ情報を更新できません"
      render :edit
    end
  end

  def memberships
    @memberships = @family.memberships.page(params[:page])
  end

  def permit
    @memberships = @family.memberships.page(params[:page])
  end

  def destroy
    @family.destroy!
    flash[:notice] = 'グループを削除しました'
    redirect_to user_path(@user)
  end

  private

  def set_family
    @family = Family.find(params[:id])
  end

  def set_user
    @user = current_user
  end

  def family_params
    params.require(:family).permit(:name, places_attributes: [:id, :name, :_destroy])
  end

  # params[:id]を持つ@familyのowner_idカラムのデータと自分のユーザーIDが一緒かどうかを確かめる。
  # 違う場合、処理をする。グループ一覧ページへ遷移させる。before_actionで使用する。
  def ensure_correct_user
    @family = Family.find(params[:id])
    unless @family.owner_id == current_user.id
      redirect_to show_user_path(current_user.id), alert: "グループオーナーのみ編集が可能です"
    end
  end
end