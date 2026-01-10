package com.swappy.sample

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatTextView

class StrokeTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = android.R.attr.textViewStyle
) : AppCompatTextView(context, attrs, defStyleAttr) {

    private var strokeColor: Int = currentTextColor
    private var strokeWidthPx: Float = 0f

    init {
        val typedArray = context.obtainStyledAttributes(attrs, R.styleable.StrokeTextView)
        strokeColor = typedArray.getColor(R.styleable.StrokeTextView_strokeColor, currentTextColor)
        strokeWidthPx = typedArray.getDimension(R.styleable.StrokeTextView_strokeWidth, 0f)
        typedArray.recycle()
    }

    override fun onDraw(canvas: Canvas) {
        if (strokeWidthPx > 0f) {
            val originalColor = currentTextColor
            val originalStyle = paint.style
            val originalWidth = paint.strokeWidth
            val originalJoin = paint.strokeJoin
            val originalMiter = paint.strokeMiter
            val originalAntiAlias = paint.isAntiAlias

            paint.style = Paint.Style.STROKE
            paint.strokeWidth = strokeWidthPx
            paint.strokeJoin = Paint.Join.ROUND
            paint.strokeMiter = 10f
            paint.isAntiAlias = true
            setTextColor(strokeColor)
            super.onDraw(canvas)

            paint.style = originalStyle
            paint.strokeWidth = originalWidth
            paint.strokeJoin = originalJoin
            paint.strokeMiter = originalMiter
            paint.isAntiAlias = originalAntiAlias
            setTextColor(originalColor)
        }

        super.onDraw(canvas)
    }
}
