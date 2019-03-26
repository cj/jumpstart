# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable and :timeoutable
  devise :masqueradable, :database_authenticatable, :registerable, :recoverable,
    :rememberable, :validatable, :omniauthable, :trackable, :confirmable

  has_person_name

  has_many :notifications, foreign_key: :recipient_id
  has_many :services

  validates :email, presence: true, uniqueness: true, format: { with: Devise.email_regexp }
  validates :name, presence: true
  validates :password, presence: true
  validates :password_confirmation, presence: true
end
