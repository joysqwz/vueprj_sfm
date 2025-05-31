export class UserDto {
	constructor(model) {
		this.sub = model.id
		this.role = model.role
		this.jti = model.jti
		this.unique_id = model.unique_id
	}
}

